import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/bloc/auth_event.dart';
import 'package:thriftin_app/bloc/auth_state.dart';
import 'package:thriftin_app/laporan/laporanAdmin/bloc/laporanadmin_bloc.dart';
import 'package:thriftin_app/laporan/laporanAdmin/bloc/laporanadmin_event.dart';
import 'package:thriftin_app/laporan/laporanAdmin/bloc/laporanadmin_state.dart';
import 'package:thriftin_app/screens/login_page.dart';
import 'package:thriftin_app/services/admin_laporan_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminLaporanBloc(AdminLaporanService())..add(FetchAllLaporan()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ],
          ),
          body: BlocBuilder<AdminLaporanBloc, AdminLaporanState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(child: Text("Error: ${state.error}"));
              }

              if (state.laporan.isEmpty) {
                return const Center(child: Text("Belum ada laporan masuk."));
              }

              return ListView.builder(
                itemCount: state.laporan.length,
                itemBuilder: (context, index) {
                  final laporan = state.laporan[index];
                  final produk = laporan['produk'];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(produk['nama_produk'] ?? '-'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Alasan: ${laporan['alasan']}"),
                          Text("Status: ${laporan['status']}"),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          final bloc = context.read<AdminLaporanBloc>();
                          if (value == 'hapus') {
                            bloc.add(DeleteProdukDariLaporan(produkId: produk['id']));
                          } else {
                            bloc.add(UpdateLaporanStatus(
                              laporanId: laporan['id'],
                              status: value,
                            ));
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'diperiksa',
                            child: Text('Tandai Diperiksa'),
                          ),
                          const PopupMenuItem(
                            value: 'selesai',
                            child: Text('Tandai Selesai'),
                          ),
                          const PopupMenuItem(
                            value: 'ditolak',
                            child: Text('Tolak'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'hapus',
                            child: Text('❌ Hapus Produk'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
